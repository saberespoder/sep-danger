# rubocop:disable all

# Helpers
require "json"
require "shellwords"

ISSUES_REPO = ENV.fetch('DANGER_ISSUES_REPO', 'saberespoder/inboundsms').freeze
DEVS = { # github username => slack username
  'dvdbng' => 'david',
  'query-string' => 'alex'
}

$had_big_fail = false
def big_fail(message)
  # PR review in slack won't be requested if there was big fails
  $had_big_fail = true
  fail message
end

added_lines = github.pr_diff.split("\n").select{ |line| line =~ /^\+/ }.join("\n")


# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
is_wip = !!(github.pr_title =~ /\bWIP\b/i) || !!(github.pr_labels.join =~ /work in progress/i)
warn("PR is classed as Work in Progress") if is_wip

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 400

# Don't let testing shortcuts get into master by accident
big_fail("fdescribe left in tests") if `grep -r fdescribe spec/ `.length > 1
big_fail("fit left in tests") if `grep -r fit spec/ `.length > 1

# Mainly to encourage writing up some reasoning about the PR
fail "Please provide a summary in the Pull Request description" if github.pr_body.length < 5

# Verify that we don't test implementation details
warn "Specs are testing implementation - assigns(:something) is used"    if added_lines =~ /expect\(assigns\(:.*\)/
warn "Specs are testing implementation - respond_to(:something) is used" if added_lines =~ /expect\(.*\).to respond_to\(:.*\)/
warn "Specs are testing implementation - receive(:something) is used"    if added_lines =~ /expect\(.*\).to receive\(:.*\)/

# We don't need any debugging code in our codebase
warn "Debugging code found - puts" if added_lines =~ /^.\s*puts\b/
big_fail "Debugging code found - binding.pry" if `grep -r binding.pry lib/ app/ spec/`.length > 1
big_fail "Debugging code found - p" if added_lines =~ /^.\s*p\b/
big_fail "Debugging code found - pp" if added_lines =~ /^.\s*pp\b/
big_fail "Debugging code found - debugger" if `grep -r debugger lib/ app/ spec/`.length > 1
big_fail "Debugging code found - console.log" if `grep -r console.log lib/ app/ spec/`.length > 1
big_fail "Debugging code found - require 'debug'" if `grep -r "require \'debug\'" lib/ app/ spec/`.length > 1

# White space conventions
fail "Trailing whitespace" if added_lines =~ /\s$/
fail "Use spaces instead of tabs for indenting" if added_lines =~ /\t/

# We don't need default_scope in our codebase
if added_lines =~ /\bdefault_scope\b/
  big_fail "default_scope found. Please avoid this bad practice ([why is bad](http://stackoverflow.com/a/25087337))"
end

# We want to merge to master only from release branches
if github.branch_for_base.eql?('master') && !(github.branch_for_head.start_with?('release_') || github.branch_for_head.start_with?('asap'))
  fail 'Your trying to rebase into MASTER from non-release branch'
end

# Warn if 'Gemfile' was modified and 'Gemfile.lock' was not
if git.modified_files.include?("Gemfile") && !git.modified_files.include?("Gemfile.lock")
  warn("`Gemfile` was modified but `Gemfile.lock` was not")
end

# See https://github.com/saberespoder/sep-danger/issues/5
if added_lines =~ /render\s.*?(&&|and)\s*return/
  big_fail "Use `return render :foo` instead of render :foo && return"
end

# Look for GIT merge conflicts
if `grep -r ">>>>\|=======\|<<<<<<<" app spec lib`.length > 1
 big_fail "Merge conflicts found"
end

# Look for timezone issues
if `grep -r "Date.today\|DateTime.now\|Time.now" app spec lib`.length > 1
  big_fail "Use explicit timezone -> https://github.com/saberespoder/officespace/blob/master/good_code.md#do-use"
end

# Encourage writing specs
warn("You've added no specs for this change. Are you sure about this?") if git.modified_files.grep(/spec/).empty?

# Code coverage metric
if File.exist?('coverage/coverage.json')
  simplecov.report 'coverage/coverage.json'
else
  fn = File.join(ENV.fetch('CIRCLE_ARTIFACTS', '.'), 'coverage/.last_run.json')
  if File.exist?(fn)
    coverage = JSON.parse(File.read(fn), symbolize_names: true)
    percent = coverage[:result][:covered_percent]
    message("Code coverage is at #{percent}%")
  else
    warn("Code coverage data not found") if `grep simplecov Gemfile`.length > 1
  end
end

# Report failed tests
tests_failed = false
rspec_report_path = File.join(ENV.fetch('CIRCLE_TEST_REPORTS', '.'), 'rspec/rspec*.xml')
rspec_reports = Dir.glob(rspec_report_path)
test_count = 0
fail_count = 0
skip_count = 0

rspec_reports.each do |rspec_report|
  junit.parse rspec_report
  junit.report
  tests_failed ||= junit.failures.length > 0
  test_count += junit.tests.length
  fail_count += junit.failures.length
  skip_count += junit.skipped.length
end

if rspec_reports.empty?
  warn "junit file not found in #{rspec_reports_path}"
else
  message "Rspec: #{test_count} examples, #{fail_count} failures, #{skip_count} skipped"
end

# Setup environment for the linters (copy configs, etc)
system("
  mv package.json package.json.bak
  mv #{__dir__}/package.json .
  npm install
  mv package.json.bak package.json
  cp -v --no-clobber #{__dir__}/linter_configs/.* #{__dir__}/linter_configs/* .
")
ENV['PATH'] = "#{`npm bin`.strip}:#{ENV['PATH']}"

# Run linters
linters = `bundle exec pronto list`.split
linters_no_errors = linters.dup

linters.each do |linter|
  report = `bundle exec pronto run --runner #{linter} --commit origin/#{github.branch_for_base} -f json`
  begin
    warnings = JSON.load(report)
  rescue
    message "Linter #{linter} failed to run"
    next
  end

  linters_no_errors.delete(linter) unless warnings.empty?

  warnings.each do |w|
    text = "#{linter}: #{w['message']} in `#{w['path']}:#{w['line']}`"
    if w['level'] = 'W'
      warn text
    else
      big_fail text
    end
  end
end
message "Linters #{linters_no_errors.join(', ')} reported no errors" unless linters_no_errors.empty?

author_github_username = github.pr_author
author_slack_username = DEVS[author_github_username]

if issue_number = github.branch_for_head[/^(\d+)_/, 1]
  begin
    issue_title = github.api.issue(ISSUES_REPO, issue_number).title
  rescue
    message "Can't find issue #{issue_number}"
  else
    markdown "Issue https://github.com/#{ISSUES_REPO}/issues/#{issue_number} (#{issue_title})"
  end
end

# Ask for reviews in slack
unless is_wip || $had_big_fail || tests_failed || !!(github.pr_labels.join =~ /review requested/i) || !github.branch_for_base.start_with?('release_')
  pr_url = github.pr_json['html_url']
  github.api.add_labels_to_an_issue(pr_url.split('/')[3..4].join('/'), pr_url.split('/')[6], ['review requested'])
  reviewers = (DEVS.values - [author_slack_username]).map { |username| "@#{username}" }.join(' ')

  text = []
  text << "#{reviewers} New Pull Request by #{(author_slack_username || 'unknown').capitalize}"
  text << "Issue: https://github.com/#{ISSUES_REPO}/issues/#{issue_number} (#{issue_title})" if issue_title
  text << "PR: #{github.pr_json["html_url"]} (#{github.pr_title})"

  payload = {
    username: 'Review bot',
    link_names: 1,
    icon_emoji: ":reviewbot-#{author_slack_username}:",
    text: text.join("\n")
  }
  system("curl -X POST --data-urlencode payload=#{payload.to_json.shellescape} '#{ENV["SLACK_REVIEW_WEBHOOK"]}'")
end
