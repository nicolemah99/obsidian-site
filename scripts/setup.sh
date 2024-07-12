#!/bin/bash

# Define the root directory of your content
CONTENT_DIR="./content"
TEMPLATE="./archetypes/default.md"

# Current date in ISO 8601 format
CURRENT_DATE=$(date -I)

# Function to apply the template
apply_template() {
  local file="$1"
  local title=$(basename "$file" .md)
  local content=$(<"$file")

  # Replace placeholders in the template
  local header=$(<"$TEMPLATE")
  header="${header//{{ title }}/$title}"
  header="${header//{{ date }}/$CURRENT_DATE}"

  # Prepend the header to the content
  echo -e "$header\n\n$content" > "$file"
  echo "Added TOML header to $file"
}

# Find all markdown files and apply the template if no front matter exists
find "$CONTENT_DIR" -type f -name "*.md" | while read -r file; do
  if ! grep -q "+++" "$file"; then
    apply_template "$file"
  fi
done

# Find all directories and ensure _index.md exists
find "$CONTENT_DIR" -type d | while read -r dir; do
  index_file="$dir/_index.md"
  if [ ! -f "$index_file" ]; then
    echo "---\ntitle: \"$(basename "$dir")\"\n---" > "$index_file"
    echo "Created _index.md in $dir"
  fi
done
