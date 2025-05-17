class StatusPagePolicy < MembershipBasedPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.where(organization_id: user.organization_id)
      else
        scope.joins(:memberships).where(memberships: { user_id: user.id })
      end
    end
  end

  def show?
    same_organization? && (viewer? || editor?)
  end

  def create?
    same_organization? && admin?
  end

  def update?
    same_organization? && editor?
  end

  def destroy?
    same_organization? && editor?
  end

  private

  def subject_page
    record
  end

  def subject_organization_id
    record.organization_id
  end
end
