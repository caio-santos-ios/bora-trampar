using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Address
    {
        [BsonElement("zip_code")]
        public string ZipCode { get; set; } = string.Empty;

        [BsonElement("street")]
        public string Street { get; set; } = string.Empty;

        [BsonElement("number")]
        public string Number { get; set; } = string.Empty;

        [BsonElement("complement")]
        public string Complement { get; set; } = string.Empty;

        [BsonElement("neighborhood")]
        public string Neighborhood { get; set; } = string.Empty;

        [BsonElement("city")]
        public string City { get; set; } = string.Empty;

        [BsonElement("state")]
        public string State { get; set; } = string.Empty;

        [BsonElement("latitude")]
        public double Latitude { get; set; } = 0.0;

        [BsonElement("longitude")]
        public double Longitude { get; set; } = 0.0;

        [BsonElement("location")]
        public AddressLocation Location { get; set; } = new();

    }

    public class AddressLocation
    {
        [BsonElement("type")]
        public string Type { get; set; } = "Point";

        [BsonElement("coordinates")]
        public double[] Coordinates { get; set; } = [];
    }
}