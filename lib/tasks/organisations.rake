# rubocop:disable all
namespace :organisations do
  desc "Import organisations into database"
  task :import => :environment do
    xlsx = Roo::Excelx.new('data/suppliers.xlsx')
    # row_length = xlsx.last_row(sheet = 0)
    # divide_rows = row_length / 5
    
    # puts row_length
    # puts divide_rows
    insert_data = []
    xlsx.each_row_streaming(pad_cells: true, offset: 1) do |row|
      puts "#{row.length} -- #{row[1].value} -- #{row[10].value}" # Array of Excelx::Cell objects

      list = { 
        'supllier_name': row[1].value,
        'active': row[10].value == 'Active'? true:false,
        'created_at': DateTime.current,
        'updated_at': DateTime.current
      }
      insert_data.push(list)
    end
    Organisation.delete_all
    Organisation.insert_all(insert_data)
  end
end
# rubocop:enable all