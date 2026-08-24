# app/policies/incident_entry_policy.rb
class IncidentEntryPolicy < ApplicationPolicy
  def create?
    same_organization? && user.admin?
  end

  def edit?
    same_organization? && user.admin?
  end

  def update?
    same_organization? && user.admin?
  end

  def destroy?
    same_organization? && user.admin?
  end

  private

  def same_organization?
    record.incident.status_page.organization_id == user.organization_id
  end
end
