class PhysicalTicketController < ApplicationController
  before_action :authenticate_user!
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource find_by: :token
  authorize_resource :conference_registrations, class: Registration

  def index
    @physical_tickets = current_user.physical_tickets.by_conference(@conference)
    @unpaid_ticket_purchases = current_user.ticket_purchases.by_conference(@conference).unpaid
  end

  def show
    @file_name = "ticket_for_#{@conference.short_title}"
    @user = @physical_ticket.user
    @ticket_layout = @conference.ticket_layout.to_sym
    respond_to do |format|
      format.html
      format.pdf do
        pdf = TicketPdf.new(@conference, @user, @physical_ticket, @ticket_layout, @file_name)
        send_data pdf.render,
                  filename: @file_name,
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end
end
