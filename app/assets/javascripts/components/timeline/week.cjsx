React           = require 'react/addons'
DND             = require 'react-dnd'
HTML5DND        = require 'react-dnd/modules/backends/HTML5'
Block           = require './block'
BlockActions    = require '../../actions/block_actions'
WeekActions     = require '../../actions/week_actions'
GradeableStore  = require '../../stores/gradeable_store'
TextInput       = require '../common/text_input'

ReactCSSTG      = React.addons.CSSTransitionGroup

Week = React.createClass(
  displayName: 'Week'
  addBlock: ->
    BlockActions.addBlock @props.week.id
  deleteBlock: (block_id) ->
    BlockActions.deleteBlock block_id
  updateWeek: (value_key, value) ->
    to_pass = $.extend(true, {}, @props.week)
    to_pass['title'] = value
    WeekActions.updateWeek to_pass
  render: ->
    blocks = @props.blocks.map (block, i) =>
      unless block.deleted
        <Block
          block={block}
          key={block.id}
          editable={@props.editable}
          gradeable={GradeableStore.getGradeableByBlock(block.id)}
          deleteBlock={@deleteBlock.bind(this, block.id)}
          moveBlock={@props.moveBlock}
        />
    blocks.sort (a, b) ->
      a.props.block.order - b.props.block.order

    if @props.editable
      addBlock = (
        <li className="row view-all">
          <div>
            <button onClick={@addBlock}>Add New Block</button>
          </div>
        </li>
      )
      deleteWeek = <button onClick={@props.deleteWeek} className='danger right'>Delete Week</button>
    if @props.showTitle == undefined || @props.showTitle
      if (@props.week.title? || @props.editable)
        spacer = '  —  '
      else
        spacer = ' '
      week_label = 'Week ' + @props.index
      start = moment(@props.start).add(7 * (@props.index - 1), 'day')
      week_label += ' (' + start.format('MM/DD') + ' - ' + start.add(6, 'day').format('MM/DD') + ')'
      title = (
        <TextInput
          onChange={@updateWeek}
          value={@props.week.title}
          value_key={'title'}
          editable={@props.editable}
          label={week_label}
          spacer={spacer}
          placeholder='Title'
        />
      )

    <li className="week">
      <div>
        {deleteWeek}
        {title}
      </div>
      <ul className="list">
        {blocks}
        {addBlock}
      </ul>
    </li>
)

module.exports = Week