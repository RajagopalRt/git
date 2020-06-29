using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models.EMS
{
    public class CommonT_LoginDTO
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string UserName { get; set; }
        public string PassWord { get; set; }
        public string Role { get; set; }
        public bool Active { get; set; }
    }
    public class SelectCommonT_LoginDTO
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Role { get; set; }
    }
    public class SaveCommonT_LoginDTO
    {
        public string Name { get; set; }
        public string UserName { get; set; }
        public string PassWord { get; set; }
        public string Role { get; set; }
    }

    public class ModifyCommonT_LoginDTO
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string UserName { get; set; }
        public string PassWord { get; set; }
        public string Role { get; set; }
        public bool Active { get; set; }
    }
    public class SelectCommonT_LoginProcDTO
    {
        public string UserName { get; set; }
        public string PassWord { get; set; }
    }
}