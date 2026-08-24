class StatusPagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(organization_id: user.organization_id)
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
    record.organization_id == user.organization_id
  end
end
