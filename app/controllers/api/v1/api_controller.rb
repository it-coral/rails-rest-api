# frozen_string_literal: true

class Api::V1::ApiController < ActionController::API
  include SharedController

  before_action :authenticate_user!
  before_action :authenticate_organization!
  before_action :set_current_time_zone
  before_action :set_locale

  # serialization_scope :view_context

  rescue_from JWT::DecodeError do |exception|
    render_error exception.message, '', 401
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    p 'ActiveRecord::RecordNotFound' if ENV['debug']
    render_404 exception.message
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render_error exception.message, '', 400
  end

  # for serializer gem
  def namespace_for_serializer
    Api::V1
  end

  def set_current_time_zone
  #   old_time_zone = Time.zone
  #   Time.zone = 'Eastern Time (US & Canada)' # todo
  # # yield
  # rescue
  #   Time.zone = old_time_zone
  end

  def render_404(msg = '')
    render_error msg, '', 404
  end

  def render_error(message = nil, error_code = '', status = 400, send_report = false, attrs = {})
    if send_report && message && !message.is_a?(String)
      # @todo airbrake?
     end

    if message.is_a?(ApplicationRecord)
      render_result message, status, message.errors.details, :errors
    else
      render_result(attrs.merge(error_code: error_code, errors: [message]), status)
    end
  end

  def serializer_params
    {
      current_user: current_user,
      current_organization: current_organization,
      current_role: current_role,
      current_course_group: current_course_group,
      current_course: current_course,
      current_group: current_group,
      current_student: current_student,
      params: params.merge(action: :show)
    }
  end

  def searializer_for(klass)
    ActiveModel::Serializer.serializer_for(klass, namespace: namespace_for_serializer)
  end

  def render_result(json, status = 200, meta = nil, meta_key = :meta)
    json.merge!(@additional_attrs_for_render) if @additional_attrs_for_render && json.respond_to?(:merge)

    res = {}
    @serializer_params = serializer_params

    if json.is_a?(Searchkick::Results)
      unless json.options[:load]
        @serializer_params[:real_collection] = json.klass.where(id: json.map(&:id))
          .each_with_object({}) { |r, h| h[r.id] = r }
      end

      res[:root] = json.klass.to_s.underscore
      res[:each_serializer] = searializer_for(json.klass)
    end

    res[:root] ||= json.base_class.to_s.underscore rescue nil

    res[:root] = res[:root].pluralize if res[:root] && json.respond_to?(:size)

    res.merge!(
      json: json,
      status: status,
      meta: meta || result_meta(json),
      meta_key: meta_key,
      serializer_params: @serializer_params
    )

    debug res

    render res
  end

  def result_meta(obj)
    meta = additional_meta || {}
    return meta if obj.is_a?(ApplicationRecord)

    if obj.respond_to?(:total_pages) # good for searchkick and kaminari
      meta[:total_pages] = obj.total_pages
    end

    meta[:total_count] = if obj.respond_to?(:total_count)
      obj.total_count
    else
      obj.unscope(:limit).count rescue nil
    end

    meta[:size] = obj.size if obj.respond_to?(:size)
    meta[:limit_value] = obj.limit_value if obj.respond_to?(:limit_value)
    meta[:current_page] = obj.current_page if obj.respond_to?(:current_page)
    meta
  end

  # override it.. for example:
  # def additional_meta
  #   { course: searializer_for(Course).new(@course, serializer_params) }
  # end
  def additional_meta
    {}
  end

  def set_locale
    return unless I18n.config.available_locales.include?(params[:locale]&.to_sym)

    I18n.locale = params[:locale]
  end

  private

  def token_changed?(token)
    session['token'] != token
  end

  def save_token(token)
    session['token'] = token
  end

  def current_user
    token = (request.headers['Authorization'] || params[:authorization]).to_s.split(' ').last

    return @current_user if @current_user && !token_changed?(token)

    save_token(token)

    if @current_user = User.find_by_token(token)
      sign_in('user', @current_user)
    end

    @current_user
  end

  def authenticate_user!(_opts = {})
    render_error('You are not authorized', nil, 401) unless current_user
  end

  def authenticate_organization!
    return true if current_organization && policy(current_organization).show?

    render_error('Organization is not determinated', nil, 428)
  end
end
