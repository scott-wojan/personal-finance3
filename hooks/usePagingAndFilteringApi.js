import axios from "axios";
import { useReducer, useState } from "react";
import { useQuery } from "react-query";

export function usePagingAndFilteringApi(params) {
  if (!params.url) {
    throw new Error("No url specified");
  }

  const { page = pagingDefaults.page, pageSize = pagingDefaults.pageSize } =
    params.payload;
  const [pagingSorting, dispatch] = useReducer(pagingReducer, {
    ...{ page, pageSize },
  });
  const [filtersAndSorting, setFiltersAndSorting] = useState({});
  const { isLoading, error, data } = useQuery(
    [params, pagingSorting, filtersAndSorting],
    async () => {
      // console.log("useQuery", params.url, {
      //   ...params.payload,
      //   ...pagingSorting,
      //   ...filtersAndSorting,
      // });
      const res = await axios.post(`/api/${params.url}`, {
        ...params.payload,
        ...pagingSorting,
        ...filtersAndSorting,
      });
      return res.data;
    },
    {
      keepPreviousData: true,
      staleTime: Infinity,
    }
  );

  const setPage = (page) => {
    // @ts-ignore
    dispatch({ type: PAGE_CHANGED, payload: page });
  };

  const setPageSize = (pageSize) => {
    // @ts-ignore
    dispatch({ type: PAGE_SIZE_CHANGED, payload: pageSize });
  };

  return {
    isLoading,
    error,
    data,
    page: pagingSorting.page,
    pageSize: pagingSorting.pageSize,
    setPage,
    setPageSize,
    setFiltersAndSorting,
  };
}

const PAGE_CHANGED = "PAGE_CHANGED";
const PAGE_SIZE_CHANGED = "PAGE_SIZE_CHANGED";

const pagingReducer = (state, { type, payload }) => {
  switch (type) {
    case PAGE_CHANGED:
      return {
        ...state,
        page: payload,
      };
    case PAGE_SIZE_CHANGED:
      return {
        ...state,
        pageSize: payload,
      };
    default:
      throw new Error(`Unhandled action type: ${type}`);
  }
};

const pagingDefaults = {
  page: 1,
  pageSize: 10,
};
