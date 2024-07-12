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

  # Read the contents of the template
  local template_content=$(<"$TEMPLATE")

  # Replace placeholders in the template content
  template_content="${template_content//\{\{ .Title \}\}/$title}"
  template_content="${template_content//\{\{ .Date \}\}/$CURRENT_DATE}"

  # Prepend the template to the file content
  echo -e "$template_content\n\n$content" > "$file"
  echo "Prepended template content to $file"
}

# Find all markdown files and apply the template if no front matter exists
find "$CONTENT_DIR" -type f -name "*.md" ! -path "$CONTENT_DIR/.obsidian/*" | while read -r file; do
  if ! grep -q "+++" "$file"; then
    apply_template "$file"
  fi
done

# Find all directories and ensure _index.md exists, excluding .obsidian directory
find "$CONTENT_DIR" -type d ! -path "$CONTENT_DIR/.obsidian*" | while read -r dir; do
  index_file="$dir/_index.md"
  if [ ! -f "$index_file" ]; then
    echo -e "+++\ntitle = \"$(basename "$dir")\"\ndate = \"$CURRENT_DATE\"\n+++" > "$index_file"
    echo "Created _index.md in $dir"
  fi
done
