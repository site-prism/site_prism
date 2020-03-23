# frozen_string_literal: true

Then('I can see a collection of sections') do
  results = @test_site.nested_sections.search_results
  results.each_with_index do |search_result, index|
    expect(search_result.description.text).to eq("Result #{index}")
  end

  expect(results.size).to eq(4)
end

Then('I can see a collection of anonymous sections') do
  anonymous_sections = @test_site.nested_sections.anonymous_sections
  anonymous_sections.each_with_index do |section, index|
    expect(section.title.text).to eq("Section #{index}")
  end

  expect(anonymous_sections.size).to eq(2)
end

Then('I can execute in the context of each section by passing a block to within') do
  block_inner_executions = 0

  expect(@test_site.nested_sections).to have_search_results(count: 4)

  @test_site.nested_sections.search_results.first.within do |sec|
    block_inner_executions += 1

    expect(sec).to be_an_instance_of(SearchResults)
    expect(sec).to have_text('Result 0')
  end

  @test_site.nested_sections.search_results.last.within do |sec|
    block_inner_executions += 1
    expect(sec).to be_an_instance_of(SearchResults)
    expect(sec).to have_text('Result 3')
  end

  @test_site.nested_sections.search_results.each do |sec|
    block_inner_executions += 1

    expect(sec).to be_an_instance_of(SearchResults)
    expect(sec).to have_text(/Result/)
  end

  expect(block_inner_executions).to eq 6
end
