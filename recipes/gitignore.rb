say "Ignore some more files, it is not personal..."

append_to_file GITIGNORE_FILE do
  %{
vendor/bundle
.idea/

}
end

bundle

git_commit "Adding development gems"
