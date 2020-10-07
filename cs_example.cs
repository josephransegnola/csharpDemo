using System;
using System.Configuration;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using MongoDB.Driver;

namespace MongoDBCSharpCRUDExample {
    public class TenantsRepository
    {
        private IMongoClient _client;
        private IMongoDatabase _database;
        private IMongoCollection<Tenant> _tenantsCollection;
        
        public TenantsRepository(string connectionString)
        {
            _client = new MongoClient(connectionString);
            _database = _client.GetDatabase("databaseName");
            _tenantsCollection = _database.GetCollection<Tenant>("tenants");
        }

        // Example of a single Insert
        public async Task InsertTenant(Tenant tenant)
        {
            await _tenantsCollection.InsertOneAsync(tenant);
        }

        // Example of a Read All.
        public async Task<List<Tenant>> GetAllTenants()
        {
            return await _tenantsCollection.Find(new BsonDocument()).ToListAsync();
        }

        // Find a single Tenant.
        public async Task<List<Tenant>> GetTenantByField(string fieldName, string fieldValue)
        {
            var filter = Builders<Tenant>.Filter.Eq(fieldName, fieldValue);
            var result = await _tenantsCollection.Find(filter).ToListAsync();
            
            return result;
        }


        // Updating a Tenant
        public async Task<bool> UpdateTenant(ObjectId id, string updateFieldName, string updateFieldValue)
        {
            var filter = Builders<Tenant>.Filter.Eq("_id", id);
            var update = Builders<Tenant>.Update.Set(updateFieldName, updateFieldValue);
            
            var result = await _tenantsCollection.UpdateOneAsync(filter, update);
            
            return result.ModifiedCount != 0;
        }

        // Delete a Tenant.
        public async Task<bool> DeleteTenantById(ObjectId id)
        {
            var filter = Builders<Tenant>.Filter.Eq("_id", id);
            var result = await _tenantsCollection.DeleteOneAsync(filter);
            return result.DeletedCount != 0;
        }
 

    }
    class Tenant {

        [BsonId]
        public ObjectId Id { get; set; }
        
        [BsonElement("HomeRealm")]
        private string HomeRealm { get; set; }

        [BsonElement("Name")]
        private string Name { get; set; }

        [BsonElement("Created")]
        private DateTime createdTime { get; set; }

        [BsonElement("Organizations")]
        private ICollection Organizations { get; set; }

        [BsonElement("ProvisioningState")]
        private string ProvisioningState { get; set; }

        [BsonElement("Users")]
        private ICollection Users { get; set; }

        [BsonElement("LicenseExpiry")]
        private DateTime LicenseExpiry { get; set; }

        [BsonElement("LicenseState")]
        private string LicenseState { get; set; }

        [BsonElement("LicenseEntries")]
        private ICollection LicenseEntries { get; set; }

        [BsonElement("SalesforceId")]
        private string SalesforceId { get; set; }

        [BsonElement("AorName")]
        private string AorName { get; set; }

        [BsonElement("AorEmail")]
        private string AorEmail { get; set; }
    }
}