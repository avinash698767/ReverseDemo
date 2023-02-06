import ballerinax/amadeus.flightoffersprice;
import ballerinax/amadeus.flightofferssearch;

import ballerina/http;

configurable string ClientSecret = ?;
configurable string ClientID = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get FlightAvailability(int Adults = 1, string DepartureDate = "06/04/2023", string From = "Mumbai", string To = "Hyderabad") returns json|error {
        // Send a response back to the caller.

        flightofferssearch:Client flightofferssearchEp = check new (config = {
            auth: {
                clientId: ClientID,
                clientSecret: ClientSecret
            }
        });
        flightofferssearch:Success getFlightOffersResponse = check flightofferssearchEp->getFlightOffers(originLocationCode = From, destinationLocationCode = To, departureDate = DepartureDate, adults = Adults);
        if <int>getFlightOffersResponse.length() > 0 {

            flightoffersprice:Client flightofferspriceEp = check new (config = {
                auth: {
                    clientId: ClientID,
                    clientSecret: ClientSecret
                }
            });

            flightofferssearch:FlightOffer[] var1 = getFlightOffersResponse.data;
            flightoffersprice:SuccessPricing _ = check flightofferspriceEp->quoteAirOffers(xHttpMethodOverride = "GET", payload = {
                data: {
                    'type: "FlightOffersPricing",
                    flightOffers: var1
                }
            });
            return getFlightOffersResponse.toJson();
        } else {

            return "No Seats Available";
        }
    }
}

