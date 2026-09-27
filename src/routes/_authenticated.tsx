import { createFileRoute } from "@tanstack/react-router";
import { WorkspaceShell } from "@/components/certibulk/workspace-shell";
export const Route=createFileRoute("/_authenticated")({component:WorkspaceShell});
