require "#{Rails.root}/lib/importers/revision_importer"

#= Routines for keeping revision data consistent
class RevisionsCleaner
  def initialize(wiki)
    @wiki = wiki
  end

  ###############
  # Entry point #
  ###############
  def self.repair_orphan_revisions
    orphan_revisions = find_orphan_revisions
    return if orphan_revisions.blank?
    orphan_revisions.group_by(&:wiki).each do |wiki, revisions|
      new(wiki).attempt_repair(revisions)
    end
  end

  #################
  # Helper method #
  #################

  def self.find_orphan_revisions
    article_ids = Article.all.pluck(:id)
    orphan_revisions = Revision
                       .where.not(article_id: article_ids)
                       .order('date ASC')

    Rails.logger.info "Found #{orphan_revisions.count} orphan revisions"
    orphan_revisions
  end

  def attempt_repair(orphan_revisions)
    start = before_earliest_revision(orphan_revisions)
    end_date = after_latest_revision(orphan_revisions)

    user_ids = orphan_revisions.map(&:user_id).uniq
    users = User.where(id: user_ids)

    revs = RevisionImporter.new(@wiki).get_revisions_for_users(users, start, end_date)
    Rails.logger.info "Imported articles for #{revs.count} revisions"

    rebuild_articles_courses_for(revs)
  end

  private

  def rebuild_articles_courses_for(revisions)
    return if revisions.blank?
    new_rev_user_ids = revisions.map(&:user_id)
    course_ids = CoursesUsers
                 .where(user_id: new_rev_user_ids, role: CoursesUsers::Roles::STUDENT_ROLE)
                 .pluck(:course_id).uniq
    course_ids.each do |course_id|
      ArticlesCourses.update_from_course(Course.find(course_id))
    end
  end

  def before_earliest_revision(revisions)
    earliest_revision = revisions.min { |a, b| a.date <=> b.date }
    date = earliest_revision.date - 1.day
    date.strftime('%Y%m%d')
  end

  def after_latest_revision(revisions)
    latest_revision = revisions.max { |a, b| a.date <=> b.date }
    date = latest_revision.date + 1.day
    date.strftime('%Y%m%d')
  end
end
