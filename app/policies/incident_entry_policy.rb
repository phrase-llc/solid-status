class IncidentEntryPolicy < ApplicationPolicy
  def create?
    membership&.role == "editor"
  end

  private

  def membership
    @membership ||= Membership.find_by(user: user, product: record.incident.product)
  end
end
