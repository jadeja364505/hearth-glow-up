import { Link } from "@tanstack/react-router";
import { Hexagon } from "lucide-react";
import { cn } from "@/lib/utils";

export function Brand({ compact = false, className }: { compact?: boolean; className?: string }) {
  return <Link to="/" className={cn("inline-flex items-center gap-2.5", className)} aria-label="Certibulk home">
    <span className="relative grid size-8 place-items-center rounded-md border border-primary/50 bg-primary/10 text-primary shadow-glow"><Hexagon className="size-4" strokeWidth={2.2}/><span className="absolute size-1.5 rounded-full bg-primary" /></span>
    {!compact && <span className="text-lg font-extrabold text-foreground">CERTIBULK</span>}
  </Link>;
}
