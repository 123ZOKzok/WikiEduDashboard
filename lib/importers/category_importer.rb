# frozen_string_literal: true

require_dependency "#{Rails.root}/lib/replica"
require_dependency "#{Rails.root}/lib/importers/revision_score_importer"
require_dependency "#{Rails.root}/lib/importers/article_importer"
require_dependency "#{Rails.root}/lib/importers/average_views_importer"
require_dependency "#{Rails.root}/lib/category_utils"
require_dependency "#{Rails.root}/lib/wiki_api"

#= Imports articles for a category, along with view data and revision scores
class CategoryImporter
  ################
  # Entry points #
  ################
  def initialize(wiki, opts={})
    @wiki = wiki
    @depth = opts[:depth] || 0
    @min_views = opts[:min_views] || 0
    @max_wp10 = opts[:max_wp10] || 100
  end

  def mainspace_page_titles_for_category(category, depth=0)
    CategoryUtils.get_titles_without_prefixes(page_data_for_category(category, depth))
  end

  def page_titles_for_category(category, depth=0, namespace=nil)
    page_data_for_category(category, depth, namespace, 'title')
  end

  private

  def page_data_for_category(category, depth=0, namespace=nil, property=nil)
    cat_query = category_query(category, namespace)
    page_data = get_category_member_data(cat_query, property)
    if depth.positive?
      depth -= 1
      subcats = subcategories_of(category)
      subcats.each do |subcat|
        page_data += page_data_for_category(subcat, depth, namespace, property)
      end
    end
    page_data
  end

  def get_category_member_data(query, property)
    data_values = []
    continue = true
    until continue.nil?
      cat_response = WikiApi.new(@wiki).query query
      page_data = cat_response.data['categorymembers']
      page_data.each do |page|
        data_values << property.present? ? page[property] : page
      end

      continue = cat_response['continue']
      query['cmcontinue'] = continue['cmcontinue'] if continue
    end
    data_values
  end

  def subcategories_of(category)
    subcat_query = category_query(category, 14) # 14 is the Category namespace
    subcats = get_category_member_data(subcat_query, 'title')
    subcats
  end

  def category_query(category, namespace=0)
    { list: 'categorymembers',
      cmtitle: category,
      cmlimit: 500,
      cmnamespace: namespace, # mainspace articles by default
      continue: '' }
  end
end
