import { Link } from "@tanstack/react-router";
import { Menu, X } from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Brand } from "./brand";

const links = [{to:"/templates",label:"Templates"},{to:"/pricing",label:"Pricing"}] as const;
export function PublicHeader() {
  const [open,setOpen]=useState(false);
  return <header className="sticky top-0 z-50 border-b border-border/70 bg-background/85 backdrop-blur-xl"><div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-5 lg:px-8"><Brand/><nav className="hidden items-center gap-7 md:flex">{links.map(x=><Link key={x.to} to={x.to} activeProps={{className:"text-foreground"}} className="text-sm font-semibold text-muted-foreground hover:text-foreground">{x.label}</Link>)}</nav><div className="hidden items-center gap-2 md:flex"><Button variant="ghost" asChild><Link to="/auth">Sign in</Link></Button><Button asChild><Link to="/auth" search={{mode:"register"}}>Start issuing <span aria-hidden>→</span></Link></Button></div><Button variant="ghost" size="icon" className="md:hidden" aria-label={open?"Close menu":"Open menu"} onClick={()=>setOpen(!open)}>{open?<X/>:<Menu/>}</Button></div>{open&&<nav className="border-t border-border px-5 py-4 md:hidden"><div className="flex flex-col gap-2">{links.map(x=><Link key={x.to} to={x.to} className="rounded-md px-3 py-3 text-sm font-semibold" onClick={()=>setOpen(false)}>{x.label}</Link>)}<Button asChild><Link to="/auth" search={{mode:"register"}}>Start issuing</Link></Button></div></nav>}</header>;
}
export function PublicFooter(){return <footer className="border-t border-border bg-surface/40"><div className="mx-auto grid max-w-7xl gap-8 px-5 py-10 sm:grid-cols-2 lg:px-8"><div><Brand/><p className="mt-4 max-w-sm text-sm leading-6 text-muted-foreground">A precise production desk for designing, validating, and issuing certificate batches.</p></div><div className="flex gap-6 sm:justify-end"><Link to="/templates" className="text-sm text-muted-foreground hover:text-foreground">Templates</Link><Link to="/pricing" className="text-sm text-muted-foreground hover:text-foreground">Pricing</Link><Link to="/auth" className="text-sm text-muted-foreground hover:text-foreground">Sign in</Link></div></div></footer>}
