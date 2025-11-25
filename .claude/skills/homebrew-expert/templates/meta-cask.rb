cask "my-meta-installer" do
  version "1.0.0"
  sha256 :no_check

  url "https://formulae.brew.sh/api/cask.json"
  name "My Meta Installer"
  desc "Installs multiple related packages"
  homepage "https://github.com/username/repo"

  depends_on formula: "jq"  # If needed for JSON parsing

  preflight do
    require "open3"
    require "json"

    # Download and parse package list
    json_data = File.read(staged_path / "cask.json")
    packages = JSON.parse(json_data)

    # Filter packages based on your criteria
    filtered = packages.select { |p| p["some_field"] == "some_value" }

    # Load exclusion list if it exists
    exclusion_file = Dir.glob("exclusions_*.txt").max_by { |f| File.mtime(f) }
    if exclusion_file && File.exist?(exclusion_file)
      excluded = File.readlines(exclusion_file).map(&:strip)
      filtered.reject! { |p| excluded.include?(p["token"]) }
    end

    puts "Installing #{filtered.size} packages..."

    # Install packages
    failed = []
    filtered.each_with_index do |pkg, idx|
      puts "[#{idx + 1}/#{filtered.size}] Installing #{pkg['token']}..."
      success = system "brew", "install", "--cask", pkg["token"]
      failed << pkg["token"] unless success
    end

    # Save failed packages for next run
    if failed.any?
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      File.write("exclusions_#{timestamp}.txt", failed.join("\n"))
      puts "Failed packages saved to exclusions_#{timestamp}.txt"
    end
  end

  caveats <<~EOS
    All packages have been installed.
    Check the logs above for any failures.
  EOS
end
