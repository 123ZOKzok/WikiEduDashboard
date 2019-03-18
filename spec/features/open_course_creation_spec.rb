# frozen_string_literal: true

require 'rails_helper'

def fill_out_open_course_creator_form
  fill_in 'Program title:', with: '한국어'
  fill_in 'Institution:', with: 'العَرَبِية'
  find('#course_description').set('This is the template description')
end

def fill_out_open_course_creator_dates_form
  find('.course_start-datetime-control input').set(Date.new(2017, 1, 4))
  find('.course_end-datetime-control input').set(Date.new(2017, 2, 1))
  page.find('body').click
end

def choose_course_type
  find('.program-description', text: /Edit-A-Thon/).click
end

describe 'open course creation', type: :feature, js: true do
  let(:user) { create(:user) }
  let(:campaign) do
    create(:campaign,
           id: 10001,
           title: 'My Awesome Campaign',
           description: 'This is the best campaign',
           default_course_type: 'Editathon',
           default_passcode: 'passcode',
           template_description: 'This is the template description')
  end

  before do
    stub_wiki_validation
    @system_time_zone = Time.zone
    Time.zone = 'UTC'
    page.current_window.resize_to(1920, 1080)

    allow(Features).to receive(:open_course_creation?).and_return(true)
    allow(Features).to receive(:disable_wiki_output?).and_return(true)
    allow(Features).to receive(:default_course_type).and_return('BasicCourse')
    allow(Features).to receive(:default_course_string_prefix).and_return('courses_generic')
    allow(Features).to receive(:wiki_ed?).and_return(false)
    login_as(user)
  end

  after do
    Time.zone = @system_time_zone
  end

  it 'lets a user create a course immediately', js: true do
    visit root_path
    click_link 'Create an Independent Program'
    choose_course_type
    fill_out_open_course_creator_form
    fill_in 'Home language:', with: 'ta'
    fill_in 'Home project', with: 'wiktionary'
    click_button 'Next'
    fill_out_open_course_creator_dates_form
    all('.time-input__hour')[0].find('option[value="15"]').select_option
    all('.time-input__minute')[0].find('option[value="35"]').select_option
    click_button 'Create my Program!'
    sleep 1
    expect(page).to have_content 'This project has been published!'
    expect(Course.last.campaigns.count).to eq(1)
    expect(Course.last.home_wiki.language).to eq('ta')
    expect(Course.last.home_wiki.project).to eq('wiktionary')
    expect(Course.last.start).to eq(Time.zone.parse('2017-01-04 15:35:00').in_time_zone('UTC'))
    expect(Course.last.type).to eq('Editathon')
  end

  it 'defaults to English Wikipedia' do
    visit root_path
    click_link 'Create an Independent Program'
    choose_course_type
    fill_out_open_course_creator_form
    click_button 'Next'
    fill_out_open_course_creator_dates_form
    click_button 'Create my Program!'
    expect(page).to have_content 'This project has been published!'
    expect(Course.last.campaigns.count).to eq(1)
    expect(Course.last.home_wiki.language).to eq('en')
    expect(Course.last.home_wiki.project).to eq('wikipedia')
  end

  it 'enables the "find your program" button' do
    visit root_path
    click_link 'Find a Program'
    page.find('section#courses')
  end

  it 'creates a course belonging to a given campaign' do
    visit course_creator_path(campaign_slug: campaign.slug)
    expect(page).to have_content campaign.title
    fill_out_open_course_creator_form
    click_button 'Next'
    fill_out_open_course_creator_dates_form
    click_button 'Create my Program!'
    sleep 1
    expect(CampaignsCourses.last.campaign_id).to eq(campaign.id)
    expect(CampaignsCourses.last.course_id).to eq(Course.last.id)
    expect(Course.last.description).to eq(campaign.template_description)
    expect(Course.last.type).to eq('Editathon')
    expect(Course.last.passcode).to eq('passcode')
  end
end
