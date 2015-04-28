say "Ignore some more files, it is not personal..."

append_to_file '.gitignore' do
"vendor/bundle
.idea/"
end

bundle

git_commit "Do not pollute the repo"
