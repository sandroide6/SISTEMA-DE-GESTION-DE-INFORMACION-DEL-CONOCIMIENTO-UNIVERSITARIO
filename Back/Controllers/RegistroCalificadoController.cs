
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ApiGenericaCsharp.Data;
using ApiGenericaCsharp.Modelos;

[ApiController]
[Route("api/[controller]")]
public class RegistroCalificadoController : ControllerBase
{
    private readonly AppDbContext _context;

    public RegistroCalificadoController(AppDbContext context)
    {
        _context = context;
    }

    // GET
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var data = await _context.RegistrosCalificados.ToListAsync();
        return Ok(data);
    }

    // GET BY ID
    [HttpGet("{id}")]
    public async Task<IActionResult> Get(int id)
    {
        var item = await _context.RegistrosCalificados.FindAsync(id);
        if (item == null) return NotFound();

        return Ok(item);
    }

    // POST
    [HttpPost]
    public async Task<IActionResult> Create(RegistroCalificado model)
    {
        _context.RegistrosCalificados.Add(model);
        await _context.SaveChangesAsync();

        return Ok(model);
    }

    // PUT
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, RegistroCalificado model)
    {
        if (id != model.Codigo)
            return BadRequest();

        _context.Entry(model).State = EntityState.Modified;
        await _context.SaveChangesAsync();

        return Ok(model);
    }

    // DELETE
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.RegistrosCalificados.FindAsync(id);
        if (item == null) return NotFound();

        _context.RegistrosCalificados.Remove(item);
        await _context.SaveChangesAsync();

        return Ok();
    }
}