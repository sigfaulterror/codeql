// generated by codegen/codegen.py
import codeql.swift.elements
import TestUtils

from PoundDiagnosticDecl x, ModuleDecl getModule, int getKind, StringLiteralExpr getMessage
where
  toBeTested(x) and
  not x.isUnknown() and
  getModule = x.getModule() and
  getKind = x.getKind() and
  getMessage = x.getMessage()
select x, "getModule:", getModule, "getKind:", getKind, "getMessage:", getMessage
