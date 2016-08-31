require '../../testHelper'
TrainingSlideHandler = require '../../../app/assets/javascripts/training/components/training_slide_handler.cjsx'
SlideMenu = require '../../../app/assets/javascripts/training/components/slide_menu.cjsx'


describe 'SlideMenu', ->
  params = {library_id: 'foo', module_id: 'bar', slide_id: 'kittens'}
  slide = {id: 1, enabled: true, title: 'How to Kitten', slug: 'kittens'}
  TestMenu = ReactTestUtils.renderIntoDocument(
    <TrainingSlideHandler
      loading=false
      params={params}>
      <SlideMenu params={params} />
    </TrainingSlideHandler>
  )

  beforeEach ->
    TestMenu.setState(
      loading: false,
      currentSlide: {content: 'hello', id: 'kittens'},
      slides: [slide],
      enabledSlides: [slide],
      nextSlide: { slug: 'foobar' },
    )

  it 'renders an ol', ->
    menu = ReactTestUtils.scryRenderedComponentsWithType(TestMenu, SlideMenu)[0]
    menuNode = ReactDOM.findDOMNode(menu)
    expect($(menuNode).find('ol').length).to.eq 1

  it 'links to a slide', ->
    menu = ReactTestUtils.scryRenderedComponentsWithType(TestMenu, SlideMenu)[0]
    menuNode = ReactDOM.findDOMNode(menu)
    expect($(menuNode).find('a').attr('href')).to.eq('/training/foo/bar/kittens')
