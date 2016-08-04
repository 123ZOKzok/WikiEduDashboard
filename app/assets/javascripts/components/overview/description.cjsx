React             = require 'react'
Editable          = require('../high_order/editable.jsx').default
TextInput         = require '../common/text_input.cjsx'
TextAreaInput     = require('../common/text_area_input.jsx').default
CourseStore       = require '../../stores/course_store.coffee'
CourseActions     = require('../../actions/course_actions.js').default
ServerActions     = require('../../actions/server_actions.js').default

getState = (course_id) ->
  course: CourseStore.getCourse()

Description = React.createClass(
  displayName: 'Description'
  updateDescription: (value_key, value) ->
    to_pass = @props.course
    to_pass[value_key] = value
    CourseActions.updateCourse to_pass
  render: ->
    <div className='module course-description'>
      <div className="section-header">
        <h3>{@props.course.title}</h3>
        {@props.controls()}
      </div>
      <div className='module__data'>
        <TextAreaInput
          onChange={@updateDescription}
          value={@props.course.description}
          placeholder={I18n.t('courses.creator.course_description')}
          value_key={'description'}
          editable={@props.editable}
          markdown=true
          autoExpand=true
        />
      </div>
    </div>
)

module.exports = Editable(Description, [CourseStore], CourseActions.persistCourse, getState, "Edit Description")
