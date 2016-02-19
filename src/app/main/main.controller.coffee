angular.module 'oekoKostenrechner'
  .controller 'MainController', ($state, $translate, $uibModal, processor, MAIN)->
    'ngInject'
    new class MainController
      constructor: ->
        @processor = processor
        @listedSettings = do processor.getListedSettings
        # Vehicles created by the user
        @vehicles = []
        # do @addDefaultVehicles
        # @openVehicle @vehicles[0], 0
        # $state.go 'main.chart'
      # Get/Set current language
      use: $translate.use
      addDefaultVehicles: ->
        @vehicles = []
        # Dummy vehicles
        for i in [0..1]
          @addVehicle
            "acquisition_year": 2014 + Math.round(Math.random()*5)
            "car_type": ["klein", "mittel", "groß"][i]
            "energy_type": ["benzin", "diesel", "BEV"][i]
      updateComputedCosts: =>
        vehicle.computeCosts() for vehicle in @vehicles
      openVehicle: (vehicle, index)->
        @vehicleModal = $uibModal.open
          animation: yes
          size: 'lg'
          templateUrl: 'app/main/vehicle/vehicle.html'
          controller: 'MainVehicleController'
          controllerAs: 'modal'
          resolve:
            vehicle:   -> vehicle
            index:     -> index
            processor: -> processor
        @vehicleModal.result.then @updateComputedCosts
      hasNoParent: (setting)->
        setting.parentid is '' or isNaN setting.parentid
      filterSetting: (vehicle)=>
        (setting)=>
          vehicle[setting.name]? and @hasNoParent setting
      removeVehicle: (index)=> @vehicles.splice index, 1
      getVehicleColor: (n)-> MAIN.COLORS[n % MAIN.COLORS.length]
      addVehicle: (params)=>
        vehicle = new Vehicle params
        # Create a uniq id for this vehiclle
        vehicle.id = do _.uniqueId
        # Create a color for this vehiclle
        vehicle.color = @getVehicleColor vehicle.id
        # Add the vehicle to the list
        @vehicles.push vehicle
