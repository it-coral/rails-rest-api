class BaseSerializer < ActiveModel::Serializer
  delegate :url_helpers, to: 'Rails.application.routes'

  def context
    view_context rescue nil
  end

  def current_user
    serializer_params[:current_user] || context&.current_user
  end

  def current_role
    @current_role ||= serializer_params[:current_role] || current_user&.role(current_organization)
  end

  def current_organization
    serializer_params[:current_organization] || context&.current_organization
  end

  def real_collection
    serializer_params[:real_collection]
  end

  def user_context
    UserContext.new current_user, current_organization
  end

  def params
    serializer_params[:params] || context&.params || {}
  end

  def serializer_params
    instance_options[:serializer_params] || {}
  end
end
