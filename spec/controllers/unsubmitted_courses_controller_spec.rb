# frozen_string_literal: true
require 'rails_helper'

describe UnsubmittedCoursesController do
  render_views

  describe '#index' do
    it 'should list courses/programs that do not have a campaigns' do
      course = create(:course, title: 'My awesome course',
                               start: Date.civil(2016, 1, 10),
                               end: Date.civil(2050, 1, 10))
      CampaignsCourses.create(course_id: course.id,
                              campaign_id: Campaign.default_campaign.id)
      course2 = create(:course, title: 'My old not as awesome course',
                                start: Date.civil(2016, 1, 10),
                                end: Date.civil(2016, 2, 10))
      get :index
      expect(response.body).to_not have_content(course.title)
      expect(response.body).to have_content(course2.title)
    end
  end
end
