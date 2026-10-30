namespace AutoServis.Model.SearchObjects;

public class VehicleSearchObject : BaseSearchObject
{
    public string? Text { get; set; }
    public int? BrandId { get; set; }

    //Owner filter. Only used for staff: a client only sees own vehicles.</summary>
    public int? UserId { get; set; }
}