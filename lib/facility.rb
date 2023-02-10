class Facility
  attr_reader :address, :phone, :add_service, :registered_vehicles, :collected_fees
  attr_accessor :services, :name
  def initialize(facility_info)
    @name = facility_info[:name]
    @address = facility_info[:address]
    @phone = facility_info[:phone]
    @services = []
    @registered_vehicles = []
    @collected_fees = 0
  end

  def add_service(service)
    @services << service
  end

  def register_vehicle(vehicle)
    service_check = services.any? {|service| service == 'Vehicle Registration'}
    if service_check == true
      @registered_vehicles << vehicle
      vehicle.registration_date = Date.today
      if (2023 - vehicle.year) >= 25
        vehicle.plate_type = :antique
        @collected_fees += 25
      elsif vehicle.engine == :ev
        vehicle.plate_type = :ev
        @collected_fees += 200
      else
        vehicle.plate_type = :regular
        @collected_fees += 100
      end
      @registered_vehicles
    else 
      return nil
    end
  end
end
