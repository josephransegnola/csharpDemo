using System;
using System.Configuration;
using MongoDBCSharpCRUDExample.TenantsRepository;

namespace csharpDemo {
    public static class Program {
        public static async Task Main(string[] args)
        {
            var repo = new TenantsRepository(ConfigurationManager.AppSettings["atlasConnectionString"]);

            
            repo.InsertTenant();


            Console.WriteLine("Finished updating the product collection");
            Console.ReadKey();
        }
    }
}