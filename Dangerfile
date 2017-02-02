# rubocop:disable all
require "json"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
if github.pr_title.include?("[WIP]") || github.pr_title.include?("[wip]") || github.pr_labels =~ /work in progress/
  warn("PR is classed as Work in Progress")
end

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 400

# Don't let testing shortcuts get into master by accident
fail("fdescribe left in tests") if `grep -r fdescribe spec/ `.length > 1
fail("fit left in tests") if `grep -r fit spec/ `.length > 1

# Ensure a clean commits history
if git.commits.any? { |c| c.message =~ /^Merge branch/ }
  fail('Please rebase to get rid of the merge commits in this PR')
end

# Mainly to encourage writing up some reasoning about the PR
if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

added_lines = github.pr_diff.split("\n").select{ |line| line =~ /^\+/ }.join("\n")

# Verify that we don't test implementation details
if added_lines =~ /expect\(assigns\(:.*\)/
  fail "Specs are testing implementation - assigns(:something) is used"
end
if added_lines =~ /expect\(.*\).to respond_to\(:.*\)/
  warn "Specs are testing implementation - respond_to(:something) is used"
end
if added_lines =~ /expect\(.*\).to receive\(:.*\)/
  warn "Specs are testing implementation - receive(:something) is used"
end

# We don't need any debugging code in our codebase
fail "Debugging code found - binding.pry" if `grep -r binding.pry lib/ app/ spec/`.length > 1
fail "Debugging code found - puts" if added_lines =~ /^.\s*puts\b/
fail "Debugging code found - p" if added_lines =~ /^.\s*p\b/
fail "Debugging code found - pp" if added_lines =~ /^.\s*pp\b/
fail "Debugging code found - debugger" if `grep -r debugger lib/ app/ spec/`.length > 1
fail "Debugging code found - console.log" if `grep -r console.log lib/ app/ spec/`.length > 1
fail "Debugging code found - require 'debug'" if `grep -r "require \'debug\'" lib/ app/ spec/`.length > 1

warn "Trailing whitespace" if added_lines =~ /\s$/
fail "Use spaces instead of tabs for indenting" if added_lines =~ /\t/

# We don't need default_scope in our codebase
if added_lines =~ /\bdefault_scope\b/
  fail "default_scope found. Please avoid this bad practice ([why is bad](http://stackoverflow.com/a/25087337))"
end

# We want to merge to master only from release branches
if github.branch_for_base.eql?('master') && !(github.branch_for_head.start_with?('release_') || github.branch_for_head.start_with?('asap'))
  fail 'Your trying to rebase into MASTER from non-release branch'
end

# Look for GIT merge conflicts
if `grep -r ">>>>\|=======\|<<<<<<<" app spec lib`.length > 1
 fail "Merge conflicts found"
end

## Look for timezone issues
if `grep -r "Date.today\|DateTime.now\|Time.now" app spec lib`.length > 1
  fail "Use explicit timezone -> https://github.com/saberespoder/officespace/blob/master/good_code.md#do-use"
end

warn("You've added no specs for this change. Are you sure about this?") if git.modified_files.grep(/spec/).empty?

if File.exist?('coverage/coverage.json')
  simplecov.report 'coverage/coverage.json'
else
  fn = File.join(ENV.fetch('CIRCLE_ARTIFACTS', '.'), 'coverage/.last_run.json')
  if File.exist?(fn)
    require 'json'
    coverage = JSON.parse(File.read(fn), symbolize_names: true)
    percent = coverage[:result][:covered_percent]
    message("Code coverage is at #{percent}%")
  else
    warn("Code coverage data not found") if `grep simplecov Gemfile`.length > 1
  end
end