({
    jsLoaded: function(component, event, helper) {
		var map = L.map('map', {zoomControl: true, tap: false}).setView([41.3136895, -95.9479626], 4);
        L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            {
                attribution: 'Tiles © Esri'
            }).addTo(map);
        component.set("v.map", map);
    },
    regattasLoaded: function(component, event, helper) {
        // Add markers
        var map = component.get('v.map');
        var regattas = event.getParam('regattas');
        for (var i=0; i<regattas.length; i++) {
            var regatta = regattas[i];
            
            var latLng = [regatta.Regatta_Location__Latitude__s, regatta.Regatta_Location__Longitude__s];
            L.marker(latLng, {regatta: regatta}).addTo(map).on('click', function(event) {
                console.log(regatta.Id);
    helper.navigateToDetailsView(event.target.options.regatta.Id);
});
        }  
    },
    regattaSelected: function(component, event, helper) {
    // Center the map on the regatta selected in the list
    var map = component.get('v.map');
    var regatta = event.getParam("regatta");
    map.panTo([regatta.Regatta_Location__Latitude__s, regatta.Regatta_Location__Longitude__s]);
}

})