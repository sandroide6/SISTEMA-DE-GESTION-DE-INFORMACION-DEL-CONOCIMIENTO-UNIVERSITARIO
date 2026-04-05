

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ApiGenericaCsharp.Data;
using ApiGenericaCsharp.Modelos;

[ApiController]
[Route("api/[controller]")]
public class ActivAcademicaController : ControllerBase
{
    private readonly AppDbContext _context;

    public ActivAcademicaController(AppDbContext context)
    {
        _context = context;
    }

    // GET
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var data = await _context.ActividadesAcademicas.ToListAsync();
        return Ok(data);
    }

    // GET BY ID
    [HttpGet("{id}")]
    public async Task<IActionResult> Get(int id)
    {
        var item = await _context.ActividadesAcademicas.FindAsync(id);
        if (item == null) return NotFound();

        return Ok(item);
    }

    // POST
    [HttpPost]
    public async Task<IActionResult> Create(ActivAcademica model)
    {
        _context.ActividadesAcademicas.Add(model);
        await _context.SaveChangesAsync();

        return Ok(model);
    }

    // PUT
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, ActivAcademica model)
    {
        if (id != model.Id)
            return BadRequest();

        _context.Entry(model).State = EntityState.Modified;
        await _context.SaveChangesAsync();

        return Ok(model);
    }

    // DELETE
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.ActividadesAcademicas.FindAsync(id);
        if (item == null) return NotFound();

        _context.ActividadesAcademicas.Remove(item);
        await _context.SaveChangesAsync();

        return Ok();
    }
}