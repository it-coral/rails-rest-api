# frozen_string_literal: true

class Api::V1::AttachmentsController < Api::V1::ApiController
  before_action :set_attachmentable
  before_action :set_attachment, except: %i[index create]

  def index
    @attachments = @attachmentable.attachments.page(current_page).per(current_count)

    render_result @attachments
  end

  def show
    render_result @attachment
  end

  def create
    @attachment = @attachmentable.attachments.new(
      user_id: current_user.id,
      organization_id: current_organization.id
    )

    if @attachment.update permitted_attributes(@attachment)
      render_result @attachment
    else
      render_error @attachment
    end
  end

  def update
    if @attachment.update_attributes permitted_attributes(@attachment)
      render_result @attachment
    else
      render_error @attachment
    end
  end

  def destroy
    @attachment.destroy

    render_result success: @attachment.destroyed?
  end

  private

  def set_attachmentable
    unless Attachment::ATTACHMENTABLES.include?(params[:attachmentable_type])
      render_error('wrong attachmentable type')
      return
    end

    @attachmentable = params[:attachmentable_type].constantize.find params[:attachmentable_id]
  end

  def set_attachment
    @attachment = @attachmentable.attachments.find params[:id]

    authorize @attachment
  end
end