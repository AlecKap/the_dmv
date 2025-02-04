require 'spec_helper'

RSpec.describe Facility do
  before(:each) do
    @facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
    @facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
    @cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice})
    @bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev})
    @camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice})
    @registrant_1 = Registrant.new('Bruce', 18, true)
    @registrant_2 = Registrant.new('Penny', 16)
    @registrant_3 = Registrant.new('Tucker', 15)
  end

  describe '#initialize' do
    it 'can initialize' do
      expect(@facility_1).to be_an_instance_of(Facility)
      expect(@facility_1.name).to eq('Albany DMV Office')
      expect(@facility_1.address).to eq('2242 Santiam Hwy SE Albany OR 97321')
      expect(@facility_1.phone).to eq('541-967-2014')
      expect(@facility_1.services).to eq([])
    end
  end

  describe '#add service' do
    it 'can add available services' do
      expect(@facility_1.services).to eq([])
      @facility_1.add_service('New Drivers License')
      @facility_1.add_service('Renew Drivers License')
      @facility_1.add_service('Vehicle Registration')
      expect(@facility_1.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
    end

    it 'can add available services' do
      @facility_1.add_service('Vehicle Registration')
      expect(@facility_1.services).to eq(['Vehicle Registration'])
    end
  end

  describe '#register vehicles' do
    it 'registers the vehicle' do
      @facility_1.add_service('Vehicle Registration')

      expect(@facility_1.registered_vehicles).to eq([])
      expect(@facility_1.collected_fees).to be(0)
      expect(@facility_1.register_vehicle(@cruz)).to be_a(Array)
      expect(@facility_1.register_vehicle(@cruz).first).to be_an_instance_of(Vehicle)
    end

    it 'has the right info' do
      @facility_1.add_service('Vehicle Registration')
      @facility_1.register_vehicle(@cruz)

      expect(@cruz.registration_date).to eq(Date.today)
      expect(@cruz.plate_type).to eq(:regular)
      expect(@facility_1.registered_vehicles).to eq([@cruz])
      expect(@facility_1.collected_fees).to be(100)
    end

    it 'can register another vehicle' do 
      @facility_1.add_service('Vehicle Registration')
      @facility_1.register_vehicle(@cruz)
      @facility_1.register_vehicle(@camaro)
      @facility_1.register_vehicle(@bolt)
      
      expect(@facility_1.registered_vehicles).to eq([@cruz, @camaro, @bolt])
      expect(@facility_1.collected_fees).to be(325)
    end

    it 'has other facility that starts empty' do
      expect(@facility_2.registered_vehicles).to eq([])
      expect(@facility_2.services).to eq([])
      expect(@facility_2.register_vehicle(@bolt)).to be(nil)
      expect(@facility_2.registered_vehicles).to eq([])
      expect(@facility_2.collected_fees).to be(0)
    end
  end
  
  describe 'has drivers licensing services' do
    describe 'Written Test' do
      it 'administers tests and renews license' do
        @facility_1.add_service('Written Test')
        @registrant_2.earn_permit
        @registrant_3.earn_permit

        expect(@facility_1.administer_written_test(@registrant_1)).to be(true)
        expect(@registrant_1.license_data).to eq({:written=> true, :license=> false, :renewed=> false})
        expect(@facility_1.administer_written_test(@registrant_2)).to be(true)
        expect(@registrant_2.license_data).to eq({:written=> true, :license=> false, :renewed=> false})
        expect(@facility_1.administer_written_test(@registrant_3)).to be(false)
        expect(@registrant_3.license_data).to eq({:written=> false, :license=> false, :renewed=> false})
      end
    end

    describe 'Road Test' do
      it '#administer_road_test' do
        @facility_1.add_service('Written Test')
        @facility_1.administer_written_test(@registrant_1)
        @registrant_2.earn_permit
        @facility_1.administer_written_test(@registrant_2)
        @facility_1.add_service('Road Test')

        expect(@facility_1.administer_road_test(@registrant_1)).to be(true)
        expect(@registrant_1.license_data).to eq({:written=> true, :license=> true, :renewed=> false})
        expect(@facility_1.administer_road_test(@registrant_2)).to be(true)
        expect(@registrant_2.license_data).to eq({:written=> true, :license=> true, :renewed=> false})
      end
    end

    describe 'Renew License' do
      before(:each) do
        @facility_1.add_service('Written Test')
        @facility_1.administer_written_test(@registrant_1)
        @registrant_2.earn_permit
        @facility_1.administer_written_test(@registrant_2)
        @facility_1.add_service('Road Test')
        @facility_1.administer_road_test(@registrant_1)
        @facility_1.administer_road_test(@registrant_2)
        @facility_1.add_service('Renew License')
      end
      it'#Renew_drivers_License' do
        expect(@facility_1.renew_drivers_license(@registrant_1)).to be(true)
        expect(@registrant_1.license_data).to eq({:written=> true, :license=>true, :renewed=>true})
        expect(@facility_1.renew_drivers_license(@registrant_2)).to be(true)
        expect(@registrant_2.license_data).to eq({:written=> true, :license=>true, :renewed=>true})
      end

      it 'does not renew license for under age registrant' do
        expect(@facility_1.renew_drivers_license(@registrant_3)).to be(false)
        expect(@registrant_3.license_data).to eq({:written=> false, :license=> false, :renewed=> false})
      end
    end
  end
end
