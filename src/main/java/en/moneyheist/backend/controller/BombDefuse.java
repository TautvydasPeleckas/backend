package en.moneyheist.backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class BombDefuse {

    @GetMapping("defuse/{code}")
    public String checkDefuseCode(@PathVariable final String code)
    {
        if(code.equals("123"))
        {return "correct";}
        return "incorrect";
    }
}
