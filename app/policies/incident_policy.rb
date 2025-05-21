# app/policies/incident_policy.rb
class IncidentPolicy < MembershipBasedPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.joins(:status_page).where(status_page: { organization_id: user.organization_id })
      else
        scope.joins(status_page: :memberships).where(memberships: { user_id: user.id })
      end
    end
  end

  def show?
    same_organization? && (viewer? || editor?)
  end

  def create?
    same_organization? && editor?
  end

  def update?
    same_organization? && editor?
  end

  def destroy?
    same_organization? && editor?
  end

  private

  def subject_page
    record.status_page
  end

  def subject_organization_id
    record.status_page.organization_id
  end
end
