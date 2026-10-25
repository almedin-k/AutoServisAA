using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;

namespace AutoServis.Services.Catalog;

public interface IPartService : IBaseCRUDService<PartResponse, PartSearchObject, PartUpsertRequest, PartUpsertRequest>
{
}
