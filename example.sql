/* SQL
====================================== 
*/
string sql = @"
SELECT DISTINCT t.Created, t.HomeRealm, t.Id, t.ProvisioningState, t.SalesforceId, i.EmailAddress AS AorEmail, tl.Expiry as LicenseExpiry, tl.State as LicenseState
FROM   tenant t
JOIN Organization o ON t.id = o.TenantId
JOIN TenantLicense tl on t.id = tl.id
JOIN [Identity] i ON i.OrganizationId = o.id 
AND i.EmailAddress = (SELECT TOP 1 i.EmailAddress
                    FROM   [Identity] i
                    JOIN IdentityAttribute ia
                    ON i.Id = ia.IdentityId
                    WHERE  i.OrganizationId = o.id
                    AND i.TenantId = t.id
                    AND ia.[Key] = 'aor'
                    AND ia.Value = 'true'
                    AND i.EmailAddress LIKE @aorEmail)
";
var result = context.Database.SqlQuery<TenantsWithAorEmailModel>( sql, new SqlParameter("@aorEmail", "%" + aorEmail + "%")).ToList();

/*Given that we remodel the data to make a more direct Tenant schema, this can be done in Mongo with a simple query
*/
db.tenants.find({$aorEmail: "<Whatever Email you're looking for>"});

/* Or, it's possible to use an Aggregation if you must keep the Collections separate. 
*/
db.tenants.aggregate([

    /* Join with organizations collection */
    {
        $lookup:{
            from: "organizations",       // other collection name
            localField: "tenantId",   // name of tenants collection field
            foreignField: "tenantId", // name of organizations collection field
            as: "organizations"         // alias for organizations collection
        }
    },
    {   $unwind:"$organization" },     // $unwind used for getting data in object or for one record only

    /* Join with tenantLicenses collection */
    {
        $lookup:{
            from: "tenantLicenses", 
            localField: "tenantId", 
            foreignField: "tenantId",
            as: "licenses"
        }
    },
    {   $unwind:"$tenantLicenses" },

    /* Join with identitys collection */
    {
        $lookup:{
            from: "identity", 
            localField: "organizationId", 
            foreignField: "organizationId",
            as: "identity"
        }
    },
    {   $unwind:"$identity" },

    /* define some conditions here */
    {
        $match:{
            $and:[{"aorEmail" : "aorEmail"}]
        }
    },

    /* define which fields are you want to fetch */
    {   
        $project:{
            _id : 1,
            created: "$tenant_created",
            homeRealm: "$tenant_homeRealm",
            tenantId: "$tenant_id",
            provisioningState: "$tenant_provisioningState",
            salesforceId: "$tenant_salesforceId",
            aorEmail: "$identity_emailAddress",
            licenseExpiration: "$tenantLicenses_licenseExpiry",
            state: "$$tenantLicenses_licenseState"
        } 
    }
]);

/* LINQ
https://mongodb.github.io/mongo-csharp-driver/2.10/reference/driver/crud/linq/ 
*/

public IQueryable<VaultPasswordTreeViewDTO> AllForTreeViewDisplayDTOReadonly(List<Guid> accessibleVaults, string filterString)
{
    var query = from vp in context.VaultPasswords
                where accessibleVaults.Contains(vp.VaultId) && vp.DisplayName.Contains(filterString)
                group vp by new { Id = vp.VaultId, vp.Vault.DisplayName } into vaultPasswordGrouping
                select new VaultPasswordTreeViewDTO
                {
                    Id = vaultPasswordGrouping.Key.Id,
                    VaultDisplayName = vaultPasswordGrouping.Key.DisplayName,
                    VaultPasswords = vaultPasswordGrouping.Select(vpg => new VaultPasswordUsernameDTO
                        {
                            Id = vpg.Id,
                            VaultId = vpg.VaultId,
                            FolderId = vpg.FolderId,
                            DisplayName = vpg.DisplayName,
                            PasswordType = vpg.PasswordType,
                            Username = vpg.Username 
                        }
                    ).ToList()
                };
    return query.AsNoTracking();
}