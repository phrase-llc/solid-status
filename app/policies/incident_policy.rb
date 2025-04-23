class IncidentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    viewer_or_editor?
  end

  def new?
    editor?
  end

  def create?
    editor?
  end

  def edit?
    editor?
  end

  def update?
    editor?
  end

  def destroy?
    editor?
  end

  private

  def viewer_or_editor?
    membership.present?
  end

  def editor?
    membership&.role == "editor"
  end

  def membership
    @membership ||= Membership.find_by(user: user, product: record.product)
  end
end
