cask "homebrew-all-fonts" do
  version "1.0.0"
  sha256 :no_check

  url "https://formulae.brew.sh/api/cask.json",
      verified: "formulae.brew.sh"
  name "Homebrew All Fonts Installer"
  desc "Install all available Homebrew Cask fonts with automatic exclusion of previously failed casks"
  homepage "https://github.com/Homebrew/homebrew-cask-fonts"

  # This is a meta-cask that doesn't install files directly
  # Instead, it provides scripts to install all available fonts

  preflight do
    require "json"
    require "open3"
    require "tempfile"
    require "fileutils"

    puts "=" * 60
    puts "Homebrew All Fonts Installer"
    puts "=" * 60
    puts ""

    # Step 1: Download the cask.json from Homebrew API
    puts "Step 1/5: Downloading cask list from Homebrew API..."
    json_data = `curl -s https://formulae.brew.sh/api/cask.json`

    if json_data.empty?
      puts "ERROR: Failed to download cask list"
      exit 1
    end

    all_casks = JSON.parse(json_data)
    puts "  ✓ Downloaded #{all_casks.length} casks"
    puts ""

    # Step 2: Filter for fonts only (ruby_source_path contains "Casks/font/")
    puts "Step 2/5: Filtering for font casks only..."
    fonts_casks = all_casks.select { |cask| cask["ruby_source_path"]&.include?("Casks/font/") }
    puts "  ✓ Found #{fonts_casks.length} font casks"
    puts ""

    # Step 3: Load invalid fonts list and filter them out
    puts "Step 3/5: Filtering out known invalid fonts..."

    # Find most recent invalid fonts list
    invalid_fonts_file = Dir.glob("invalid_brew_fonts_list_*.txt").max_by { |f| File.mtime(f) }
    previous_invalid_fonts = []

    if invalid_fonts_file && File.exist?(invalid_fonts_file)
      puts "  Using invalid fonts list: #{File.basename(invalid_fonts_file)}"
      previous_invalid_fonts = File.readlines(invalid_fonts_file).map(&:strip).reject(&:empty?)
      puts "  Loaded #{previous_invalid_fonts.length} invalid fonts from previous runs"

      fonts_filtered = fonts_casks.reject { |font| previous_invalid_fonts.include?(font["token"]) }
      filtered_count = fonts_casks.length - fonts_filtered.length
      puts "  ✓ Filtered out #{filtered_count} invalid fonts"
    else
      puts "  No invalid fonts list found, starting fresh"
      fonts_filtered = fonts_casks
      puts "  ✓ No fonts filtered (first run)"
    end

    total_fonts = fonts_filtered.length
    puts "  Final font count: #{total_fonts}"
    puts ""

    # Step 4: Convert to Brewfile
    puts "Step 4/5: Creating temporary Brewfile..."
    brewfile = Tempfile.new(["homebrew-fonts-", ".Brewfile"])

    brewfile.puts "# Homebrew All Fonts"
    brewfile.puts "# Generated: #{Time.now}"
    brewfile.puts "# Total fonts: #{total_fonts}"
    brewfile.puts ""

    fonts_filtered.each do |font|
      brewfile.puts "cask \"#{font["token"]}\""
    end

    brewfile.close
    puts "  ✓ Brewfile created with #{total_fonts} fonts"
    puts "  Location: #{brewfile.path}"
    puts ""

    # Step 5: Ask user for installation method
    puts "Step 5/5: Choose installation method:"
    puts "  1. Brew Bundle (fast - stops on first error)"
    puts "  2. Loop Method (safe - continues on errors)"
    puts "  3. Save Brewfile and Exit"
    puts "  4. Cancel"
    print "\nYour choice [1-4]: "

    choice = $stdin.gets.chomp

    case choice
    when "1"
      puts "\n" + "=" * 60
      puts "Installing with Brew Bundle Method"
      puts "=" * 60
      puts ""
      puts "⚠️  This will stop on first error"
      puts "Total fonts to install: #{total_fonts}"
      puts ""

      # Run brew bundle and capture output
      output, status = Open3.capture2e("brew", "bundle", "--file=#{brewfile.path}")
      puts output

      # Parse output to find failed fonts
      failed_fonts = []
      output.each_line do |line|
        # Match error lines like "Error: Cask 'font-name' ..."
        if line =~ /Error:.*['"]?(font-[^'"]+)['"]?/
          failed_fonts << $1
        # Match disabled casks
        elsif line =~ /Cask ['"]?(font-[^'"]+)['"]? has been disabled/
          failed_fonts << $1
        end
      end

      failed_fonts.uniq!

      # Generate updated invalid fonts list
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      new_invalid_file = "invalid_brew_fonts_list_#{timestamp}.txt"

      all_invalid_fonts = (previous_invalid_fonts + failed_fonts).uniq.sort
      File.write(new_invalid_file, all_invalid_fonts.join("\n") + "\n")

      puts ""
      puts "=" * 60
      puts "Invalid Fonts List Updated"
      puts "=" * 60
      puts "Previous invalid fonts: #{previous_invalid_fonts.length}"
      puts "Newly failed fonts:     #{failed_fonts.length}"
      puts "Total invalid fonts:    #{all_invalid_fonts.length}"
      puts "Saved to: #{new_invalid_file}"
      puts "=" * 60

      if failed_fonts.any?
        puts ""
        puts "Newly failed fonts this run:"
        failed_fonts.each { |f| puts "  - #{f}" }
      end

      brewfile.unlink
      puts "\nDone!"

    when "2"
      puts "\n" + "=" * 60
      puts "Installing with Loop Method"
      puts "=" * 60
      puts ""
      puts "⚠️  This will continue even if fonts fail"
      puts "Total fonts to install: #{total_fonts}"
      puts ""

      success = 0
      failed = 0
      failed_fonts = []

      fonts_filtered.each_with_index do |font, index|
        font_name = font["token"]
        printf "[%d/%d] Installing: %-40s ", index + 1, total_fonts, font_name

        output, status = Open3.capture2e("brew", "install", "--cask", font_name)

        if status.success? || output.include?("successfully") || output.include?("already installed") || output.include?("latest version")
          success += 1
          puts "✓"
        else
          failed += 1
          failed_fonts << font_name
          puts "✗"
        end
      end

      puts ""
      puts "=" * 60
      puts "Installation Summary"
      puts "=" * 60
      puts "Total fonts:            #{total_fonts}"
      puts "Successfully installed: #{success}"
      puts "Failed:                 #{failed}"
      puts "=" * 60

      # Generate updated invalid fonts list (previous + new failures)
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      new_invalid_file = "invalid_brew_fonts_list_#{timestamp}.txt"

      # Combine previous invalid fonts + newly failed fonts
      all_invalid_fonts = (previous_invalid_fonts + failed_fonts).uniq.sort

      File.write(new_invalid_file, all_invalid_fonts.join("\n") + "\n")

      puts ""
      puts "=" * 60
      puts "Invalid Fonts List Updated"
      puts "=" * 60
      puts "Previous invalid fonts: #{previous_invalid_fonts.length}"
      puts "Newly failed fonts:     #{failed_fonts.length}"
      puts "Total invalid fonts:    #{all_invalid_fonts.length}"
      puts "Saved to: #{new_invalid_file}"
      puts "=" * 60

      if failed_fonts.any?
        puts ""
        puts "Newly failed fonts this run:"
        failed_fonts.each { |f| puts "  - #{f}" }
      end

      brewfile.unlink
      puts "\nDone!"

    when "3"
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      saved_brewfile = "Brewfile.all-fonts.#{timestamp}"
      FileUtils.cp(brewfile.path, saved_brewfile)

      puts "\n✓ Brewfile saved to: #{saved_brewfile}"
      puts ""
      puts "To install later, run:"
      puts "  brew bundle --file=#{saved_brewfile}"
      puts ""

      brewfile.unlink

    when "4"
      puts "\nInstallation cancelled."
      brewfile.unlink
      exit 0

    else
      puts "\nInvalid choice. Installation cancelled."
      brewfile.unlink
      exit 1
    end
  end

  # Since this is a meta-cask, we create a marker file
  postflight do
    marker_dir = "#{Dir.home}/Library/Application Support/homebrew-all-fonts"
    FileUtils.mkdir_p(marker_dir)
    File.write("#{marker_dir}/.installed", Time.now.to_s)
  end

  uninstall_preflight do
    puts "⚠️  This will NOT uninstall the fonts that were installed."
    puts ""
    puts "To uninstall all fonts, run:"
    puts "  brew list --cask | grep '^font-' | xargs brew uninstall --cask"
  end

  zap trash: "#{Dir.home}/Library/Application Support/homebrew-all-fonts"

  caveats <<~EOS
    Homebrew All Fonts Installer - Smart Cask Installation

    This cask will:
    1. Fetch the latest cask definitions from formulae.brew.sh API
    2. Filter for font casks only (ruby_source_path contains "Casks/font/")
    3. Automatically exclude casks that failed in previous installations
    4. Generate a temporary Brewfile with valid casks only
    5. Install casks using your chosen method (brew bundle or loop)

    Smart Features:
    - Automatically remembers casks that failed installation
    - Skips problematic casks on subsequent runs
    - Updates exclusion list after each installation attempt
    - Maintains cumulative history of failed casks

    Total font casks available: ~2,500+
    Installation time: Several hours (first run), faster on subsequent runs

    To install new fonts and update existing ones:
      brew reinstall --cask homebrew-all-fonts

    The cask automatically maintains invalid_brew_fonts_list_*.txt files
    to exclude casks that cannot be installed (disabled, broken upstream, etc.)

    To uninstall all font casks:
      brew list --cask | grep '^font-' | xargs brew uninstall --cask

    To reset and retry all casks:
      rm invalid_brew_fonts_list_*.txt
      brew reinstall --cask homebrew-all-fonts
  EOS
end
