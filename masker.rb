require "#{__dir__}/lib/masker"
require 'thor'

class Masker::Cli < Thor
  include Thor::Actions

  desc 'mask MASKER_FILE', 'Mask database'
  def mask(masker_file)
    masker = Masker.new(masker_file)
    masker.mask
  end
end

Masker::Cli.start
