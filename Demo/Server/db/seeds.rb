file = Rails.root.join("db", "seeds", "resources.yml")
YAML.load_file(file).each do |hash|
  Resource.find_or_create_by!(title: hash["title"]) do |resource|
    resource.description = hash["description"]
  end
end
