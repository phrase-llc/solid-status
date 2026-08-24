# app/policies/incident_policy.rb
class IncidentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.joins(:status_page).where(status_pages: { organization_id: user.organization_id })
    end
  end

  def show?
    same_organization?
  end

  def create?
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
    record.status_page.organization_id == user.organization_id
  end
end
