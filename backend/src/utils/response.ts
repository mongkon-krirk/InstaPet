type PaginationMeta = {
  page: number;
  pageSize: number;
  pageCount: number;
  total: number;
  hasNextPage: boolean;
};

export const success = <T>(data: T, meta: Record<string, unknown> = {}) => ({
  data,
  meta,
  error: null,
});

export const paginated = <T>(
  data: T[],
  pagination: PaginationMeta,
  meta: Record<string, unknown> = {},
) => ({
  data,
  meta: { ...meta, pagination },
  error: null,
});

export const errorResponse = (
  code: string,
  message: string,
  details: Record<string, unknown> = {},
) => ({
  data: null,
  meta: {},
  error: { code, message, details },
});

export const buildPagination = (
  page: number,
  pageSize: number,
  total: number,
) => {
  const pageCount = Math.ceil(total / pageSize) || 0;
  return {
    page,
    pageSize,
    pageCount,
    total,
    hasNextPage: page < pageCount,
  };
};

export const parsePagination = (query: Record<string, unknown>) => {
  const page = Math.max(1, Number(query.page) || 1);
  const pageSize = Math.min(100, Math.max(1, Number(query.pageSize) || 20));
  return { page, pageSize, start: (page - 1) * pageSize };
};
