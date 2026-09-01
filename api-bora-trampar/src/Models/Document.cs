using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Document : ModelBase
    {
        [BsonElement("name")]
        public string Name { get; set; } = string.Empty;

        [BsonElement("number")]
        public string Number { get; set; } = string.Empty;

        [BsonElement("uri_file")]
        public string UriFile { get; set; } = string.Empty;
    }
}