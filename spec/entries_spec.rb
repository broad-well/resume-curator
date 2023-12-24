# typed: strict

require "entries"
require "rspec/core"

RSpec.describe ResumeEntry do
  it "should accept correctly formed resume entries" do
    entry = {
      "name"=>"csim6502",
      "tex"=> "\\ownentry{Microprocessor Emulator (``csim6502'')}{2018 -- 2018}{\\link{https://github.com/broad-well/csim6502}{GitHub}}\n\\begin{myitemize}\n  \\item Designed and implemented a complete emulator of the MOS 6502 microprocessor in maintainable, expressive C++ using strict Test-Driven Development within 2 weeks\n\\end{myitemize}",
      "appeal"=>{"testing"=>7, "security"=>2, "agile"=>3, "tdd"=>8, "ds_algo"=>2},
      "lines"=>3,
      "order"=>"2018.E.2018.C.1"
    }
    resume_entry = ResumeEntry.new(entry)
    expect(resume_entry.name).to eq "csim6502"
    expect(resume_entry.appeal["agile"]).to eq 3
    expect(resume_entry.lines).to eq 3
  end

  it "should reject entries missing a key" do
    entry = {
      "name"=>"csim6502",
      "tex"=> "\\ownentry{Microprocessor Emulator (``csim6502'')}{2018 -- 2018}{\\link{https://github.com/broad-well/csim6502}{GitHub}}\n\\begin{myitemize}\n  \\item Designed and implemented a complete emulator of the MOS 6502 microprocessor in maintainable, expressive C++ using strict Test-Driven Development within 2 weeks\n\\end{myitemize}",
      "appeal"=>{"testing"=>7, "security"=>2, "agile"=>3, "tdd"=>8, "ds_algo"=>2},
      "lines"=>3,
      "order"=>"2018.E.2018.C.1"
    }
    entry.keys.each do |key|
      item = entry.delete key
      expect { ResumeEntry.new(entry) }.to raise_error(TypeError)
      entry[key] = item
    end
  end
end
