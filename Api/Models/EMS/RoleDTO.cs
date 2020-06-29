using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class RoleDTO
    {
        public int RoleId { get; set; }
        public string Name { get; set; }
        public string Code { get; set; }
        public string CreatedBy { get; set; }
        public string ModifiedBy { get; set; }
        public DateTime ModifiedDate { get; set; }
        public DateTime CreatedDate { get; set; }
}
    public class SaveRoleDTO
    {
        public string Name { get; set; }
        public string Code { get; set; }
        public string CreatedBy { get; set; }
    }
    public class ModifyRoleDTO
    {
        public int RoleId { get; set; }
        public string Name { get; set; }
        public string Code { get; set; }
        public string ModifiedBy { get; set; }
    }
    public class RemoveRoleDTO
    {
        public int RoleId { get; set; }
    }
}