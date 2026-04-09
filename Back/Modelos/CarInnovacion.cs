using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApiGenericaCsharp.Modelos
{
    [Table("car_innovacion")]
    public class CarInnovacion
    {
        [Key]
        public int id { get; set; }

        public string nombre { get; set; } = string.Empty;

        public string tipo { get; set; } = string.Empty;

        public string? descripcion { get; set; }
    }
}