require "fileutils"

require_relative "../lib/utils"
require_relative "../lib/constraints"

# Models a scheduling problem as a SAT problem and writes it to a file
# in CNF format.
#
# @param [Integer] n_participants Number of participants
# @param [Integer] n_days Number of days
# @param [Integer] n_hours Number of hours
# @param [String] filename Name of the JSON file
# @return [String] Name of the CNF translation file
def translate_to_cnf(n_participants, n_days, n_hours, filename)
  n_available_hours = n_hours - 1
  n_variables = n_participants ** 2 * n_days * n_available_hours
  n_clauses = calculate_number_of_clauses(n_participants, n_days, n_hours)
  map_to_cnf = create_map_to_cnf(n_participants, n_days, n_hours)

  File.open(filename, "w") do |f|
    # Write header
    f.puts "c FILE: #{filename}"
    f.puts "c Generated by sat-planner v1.0.0"
    f.puts "c Chus, Ka (2023)"
    f.puts "c"

    f.puts "p cnf #{n_variables} #{n_clauses}"

    args = [f, map_to_cnf, n_participants, n_days, n_available_hours]

    write_constraint_1!(*args)
    write_constraint_2!(*args)
    write_constraint_3!(*args)
    write_constraint_4!(*args)
    write_constraint_5!(*args)
  end

  translation_filename = "tmp/" \
  "#{File.basename(filename, File.extname(filename))}_translation.cnf"

  translation_filename
end

# Calculates the number of clauses in the CNF translation.
#
# @param [Integer] n Number of participants
# @param [Integer] d Number of days
# @param [Integer] h Number of hours
# @return [Integer] Number of clauses to be written
def calculate_number_of_clauses(n, d, h)
  n_constraint_1 = n*d*(h-1)
  n_constraint_2 = n*(n-1)
  n_constraint_3 = n*(n-1)*d*(n*(n-1)-1)*(2*h-3)
  n_constraint_4 = 4*n**2 * (n-1)*d*(h-1)*(h-2)
  n_constraint_5 = 2*n**2 * (n-1)*(d-1) * (h-1)**2

  n_constraint_1 + n_constraint_2 + n_constraint_3 + n_constraint_4 + n_constraint_5
end

# Solves a SAT problem in CNF format using the minisat solver.
#
# @param [String] filename Name of the CNF file
# @param [String] bin_path Path to the SAT Solver binary
# @return [String] Name of the solution file
def solve_cnf(filename, bin_path)
  solution_filename = "tmp/" \
  "#{File.basename(filename, File.extname(filename))}_solution.cnf"

  # Run minisat
  `#{bin_path} #{filename} #{solution_filename}`

  solution_filename
end
